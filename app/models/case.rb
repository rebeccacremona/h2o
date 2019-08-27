class Case < ApplicationRecord
  include ContentAnnotatable

  include Capapi::ModelHelpers
  CAPAPI_CLASS = Capapi::Case

  store_accessor :opinions, :majority

  include Rails.application.routes.url_helpers

  has_many :casebooks, inverse_of: :contents, class_name: 'Content::Casebook', foreign_key: :resource_id
  belongs_to :case_court, optional: true, inverse_of: :cases

  accepts_nested_attributes_for :case_court,
    allow_destroy: true,
    reject_if: proc { |att| att['name'].blank? || att['name_abbreviation'].blank? }

  def display_name
    (name_abbreviation.blank?) ? name : name_abbreviation
  end

  def description
    nil
  end

  def date_year
    decision_date.try :year
  end

  alias :to_s :display_name
  alias :title :display_name

  nilify_blanks only: [:docket_number]
  
  validate :date_check

  validates :docket_number, length: {maximum: 20000}
  validates_presence_of   :name_abbreviation,      :content
  validates_length_of     :name_abbreviation,      :in => 1..150, :allow_blank => true, :allow_nil => true
  validates_length_of     :header_html,            :in => 1..(15.kilobytes), :allow_blank => true, :allow_nil => true
  validates_length_of     :content,                :in => 1..(5.megabytes), :allow_blank => true, :allow_nil => true

  searchable do
    text :name, boost: 3.0
    text :name_abbreviation
    text :docket_number
    text :indexable_case_citations, boost: 3.0
    text :indexable_case_court

    string :display_name, stored: true
    string :id, stored: true
    date :decision_date, stored: true

    time(:created_at, stored: true) { created_at.to_time }
    time(:updated_at, stored: true) { updated_at.to_time }
    boolean :public

    string :klass, :stored => true
    string(:verified_professor, stored: true)
  end
  
  alias :to_s :display_name

  def verified_professor
    # Since we're searching all models together in Sunspot, this field needs to be 
    # created so that all cases will always show up.
    true
  end

  def citations
    self[:citations] || []
  end

  def indexable_case_citations
    self.citations.pluck("cite").join(" ")
  end

  def indexable_case_court
    self.case_court.present? ? self.case_court.name : ''
  end

  def clean_content
    self.content.encode.gsub!(/\p{Cc}/, "")
    # encode needed for cap api import
  end

  def formatted_decision_date
    if self.decision_date.present?
      self.decision_date.strftime("%B %d, %Y")
    end
  end

  def associated_resources
    links = ""
    resources = Content::Resource.where(resource_type: self.class.name, resource_id: self.id)
    resources.each do |resource|
      casebook = resource.casebook
      links += "<div><a href=#{resource_path(casebook, resource)}>#{casebook.title} [#{casebook.created_at.year}] - #{casebook.owner}</a></div>"
    end
    links.html_safe
  end

  private

  def date_check
    if !self.decision_date.blank? && self.decision_date > Date.today
      errors.add(:decision_date,'cannot be in the future')
    end
  end
end
