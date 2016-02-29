# encoding: utf-8
# frozen_string_literal: true
require 'rails'

module View
  module ViewHelpers
    extend ActiveSupport::Concern
    included do
      include Rails.application.routes.url_helpers
      include Rails.application.routes.mounted_helpers

      include ActionView::Helpers::ActiveModelHelper
      include ActionView::Helpers::ActiveModelInstanceTag
      include ActionView::Helpers::AssetTagHelper
      include ActionView::Helpers::AssetUrlHelper
      include ActionView::Helpers::AtomFeedHelper
      include ActionView::Helpers::CacheHelper
      include ActionView::Helpers::CaptureHelper
      include ActionView::Helpers::ControllerHelper
      include ActionView::Helpers::CsrfHelper
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::DebugHelper
      include ActionView::Helpers::FormHelper
      include ActionView::Helpers::FormOptionsHelper
      include ActionView::Helpers::FormTagHelper
      include ActionView::Helpers::JavaScriptHelper
      include ActionView::Helpers::NumberHelper
      include ActionView::Helpers::OutputSafetyHelper
      include ActionView::Helpers::RecordTagHelper
      include ActionView::Helpers::RenderingHelper
      include ActionView::Helpers::SanitizeHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::TranslationHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Context
      def default_url_options
        ActionMailer::Base.default_url_options
      end
    end
  end
end
