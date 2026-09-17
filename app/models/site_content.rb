class SiteContent < ApplicationRecord
  include ApiJson

  self.table_name = "site_contents"
  self.primary_key = "key"

  def to_api
    {
      key: key,
      heroTitle: hero_title,
      heroSub: hero_sub,
      flagshipTitle: flagship_title,
      flagshipSub: flagship_sub,
      whatTitle: what_title,
      whatText: what_text,
      whyTitle: why_title,
      whyText: why_text,
      process: process || [],
      feedbackTitle: feedback_title,
      feedbackText: feedback_text,
      footerHeading: footer_heading,
      footerText: footer_text,
      phone: phone
    }
  end

  def apply_api_attrs(attrs)
    attrs = attrs.stringify_keys
    self.hero_title = attrs["heroTitle"] if attrs.key?("heroTitle")
    self.hero_sub = attrs["heroSub"] if attrs.key?("heroSub")
    self.flagship_title = attrs["flagshipTitle"] if attrs.key?("flagshipTitle")
    self.flagship_sub = attrs["flagshipSub"] if attrs.key?("flagshipSub")
    self.what_title = attrs["whatTitle"] if attrs.key?("whatTitle")
    self.what_text = attrs["whatText"] if attrs.key?("whatText")
    self.why_title = attrs["whyTitle"] if attrs.key?("whyTitle")
    self.why_text = attrs["whyText"] if attrs.key?("whyText")
    self.process = attrs["process"] if attrs.key?("process")
    self.feedback_title = attrs["feedbackTitle"] if attrs.key?("feedbackTitle")
    self.feedback_text = attrs["feedbackText"] if attrs.key?("feedbackText")
    self.footer_heading = attrs["footerHeading"] if attrs.key?("footerHeading")
    self.footer_text = attrs["footerText"] if attrs.key?("footerText")
    self.phone = attrs["phone"] if attrs.key?("phone")
  end
end
