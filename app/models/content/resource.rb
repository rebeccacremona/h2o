class Content::Resource < Content::Child
  default_scope {where.not(resource_id: nil)}

  belongs_to :resource, polymorphic: true, inverse_of: :casebooks, required: true
  has_many :annotations, class_name: 'Content::Annotation', dependent: :destroy

  accepts_nested_attributes_for :resource

  def can_delete?
    true
  end

  def paragraph_nodes
    HTMLHelpers.process_p_nodes(
      Nokogiri::HTML(resource.content) {|config| config.strict.noblanks})
  end

  def annotated_paragraphs
    nodes = paragraph_nodes
    #export_footnote_index determines how many astericks are next to a link or note annotation in the exported version of a resource
    export_footnote_index = 0

    annotations.order(:start_paragraph, :id).each do |annotation|
      if annotation.kind.in? %w(note link)
        export_footnote_index += 1
      end

      annotatedNodes = nodes[annotation.start_paragraph..annotation.end_paragraph]
      if annotatedNodes.nil?
        Notifier.missing_annotations(self.users.pluck(:email_address, :attribution), self, annotation)
      else
        annotatedNodes.each_with_index do |paragraph_node, paragraph_index|
          ApplyAnnotationToParagraphs.perform({annotation: annotation, paragraph_node: paragraph_node, paragraph_index: paragraph_index + annotation.start_paragraph, export_footnote_index: export_footnote_index})
        end
      end
    end

    # remove any empty nodes, usually paragraphs that were fully elided in the prev step
    nodes.filter(":not(:empty)")
  end

  def title
    super.present? ? super : resource.title
  end

  def footnote_annotations
    footnote_annotations = ""
    idx = 0

    custom_style_attribute = H2o::Application.config.pandoc_export ? 'custom-style="Footnote Reference"' : 'msword-style="FootnoteReference"'
    annotations.all.sort_by{|annotation| annotation.start_paragraph}.each do |annotation|
      if annotation.kind.in? %w(note link)
        idx += 1
        footnote_annotations += "<span #{custom_style_attribute}>#{("*" * (idx))}</span>#{ApplicationController.helpers.send(:html_escape, annotation.content)} "
      end
    end

    footnote_annotations.html_safe
  end

  def has_elisions?
    annotations.where(kind: ["elide", "replace"]).any?
  end
end
