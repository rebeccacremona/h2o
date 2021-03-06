require 'net/http'
require 'uri'

class Content::SectionsController < Content::NodeController
  before_action :prevent_page_caching, only: [:export]
  before_action :find_parent, only: [:create]
  skip_before_action :set_page_title, only: [:export]
  skip_before_action :check_public, only: [:export]

  include Export

  def create
    child_ordinals = @parent.ordinals + [@parent.children.length + 1]
    if params[:resource_id]
      resource = Case.find params[:resource_id]
      @section = Content::Resource.create! ordinals: child_ordinals, casebook:@casebook, resource: resource
    elsif params[:text]
      text = TextBlock.create(name: params[:text][:title], content: params[:text][:content])
      @section = Content::Resource.create! ordinals: child_ordinals, casebook:@casebook, resource: text
    elsif params[:link]
      url = UrlDomainFormatter.format(params[:link][:url])
      link = Default.create(url: url)
      @section = Content::Resource.create! ordinals: child_ordinals, casebook:@casebook, resource: link
    else
      @section = Content::Section.create! ordinals: child_ordinals, casebook:@casebook
    end

    if @section.is_a?(Content::Resource)
      if @section.resource_type == 'Default'
        redirect_to edit_resource_path @casebook, @section
      else
        redirect_to annotate_resource_path @casebook, @section
      end
    else
      @casebook.update_attributes public: false
      @decorated_content = @content.decorate(context: {action_name: action_name, casebook: @casebook, section: @section, context_resource: @resource, type: 'section'})
      redirect_to layout_section_path @casebook, @section
    end
  end

  def edit
    # editing a section takes you to a cloned casebook and
    # the original casebook stays published
    @casebook = @casebook.clone(true)
    @section = @casebook.contents.find_by(copy_of_id: @section.id)
    @decorated_content = @content.decorate(context: {action_name: action_name, casebook: @casebook, section: @section, type: 'section'})
    redirect_to layout_section_path(@casebook, @section)
  end

  def revise
    # revise without creating a draft
    redirect_to layout_section_path(@casebook, @section)
  end

  def show
    @decorated_content = @content.decorate(context: {action_name: action_name, casebook: @casebook, section: @section, type: 'section'})
    render 'content/show'
  end

  def update
    if @casebook.draft_mode_of_published_casebook?
      @section.create_revisions(content_params)
    end

    @section.update content_params
    return redirect_to layout_section_path(@casebook, @section) if @section.valid?
  end

  def destroy
    @section.try(:contents).try(:destroy_all)

    if !@section.destroy
      flash[:error] = "Could not delete #{@section.ordinal_string} #{@section.title}"
    end

    @section.reflow_casebook

    render status: 200, plain: "section-deleted"
  end

  def clone
    @casebook = @casebook.clone(false, current_user)
    @section = @casebook.contents.find_by(copy_of_id: @section.id)
    @decorated_content = @content.decorate(context: {action_name: action_name, casebook: @casebook, section: @section, type: 'section'})
    redirect_to layout_section_path(@casebook, @decorated_content)
  end

  def export
    export_content(Content::Section.find params[:section_id])
  end

  def reorder
    @child = @casebook.contents.find_by_ordinals parse_ordinals(params[:child_ordinals])
    @child.update_attributes ordinals: params[:child][:ordinals]
    redirect_to layout_section_path(@casebook, @section)
  end

  private

  def page_title
    if @section.present?
      if action_name == 'edit'
        I18n.t 'content.titles.sections.edit', casebook_title: @casebook.title, section_title: @section.title, ordinal_string: @section.ordinal_string
      else
        I18n.t 'content.titles.sections.show', casebook_title: @casebook.title, section_title: @section.title,  ordinal_string: @section.ordinal_string
      end
    else
      if action_name == 'new'
        I18n.t 'content.titles.casebooks.new', casebook_title: @casebook.title
      end
    end
  end
end
