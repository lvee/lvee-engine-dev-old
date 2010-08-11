module RSpec::Rails::ControllerExampleGroup
  def login_as(user)
    controller.stubs(:current_user).returns(user)
  end

  %w(get post put delete head).each do |method|
    class_eval <<-EOV, __FILE__, __LINE__
      def #{method}(action, params = {}, session = nil, flash = nil)
        @request.env['REQUEST_METHOD'] = '#{method.upcase}' if defined?(@request)
        params = {:lang=>'en'}.merge(params)
        process(action, params, session, flash)
      end
    EOV
  end
end

module RSpec::Rails::ViewExampleGroup
  def login_as(user)
    template.stubs(:current_user).returns(user)
  end

  included do
    before :each do
      params[:lang] = 'en'
    end
  end
end

I18n.class_eval(<<-END
  class << self
    def translate(key, options = {})
      locale = options.delete(:locale) || I18n.locale
      backend.translate(locale, key, options)
    end

  end
  END
)

module Kernel
  #Doesn't exec any commands
  def system(*args)
  end
end

module ActionView::Helpers::TranslationHelper
  def translate(key, options = {})
    I18n.translate(key, options)
  end

  def t(key, options = {})
    I18n.translate(key, options)
  end
end

Array.class_eval do
  alias_method(:count, :length)
end unless [].respond_to?(:count)