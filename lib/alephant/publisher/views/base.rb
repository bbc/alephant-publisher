require 'mustache'
require 'alephant/publisher/views'
require 'hashie'
require 'json'
require 'i18n'

module Alephant::Publisher::Views
  class Base < Mustache
    attr_accessor :data

    class << self
      attr_accessor :base_path
    end

    def initialize(data = {})
      @data = Hashie::Mash.new data

      load_translations_from base_path
    end

    def locale
      :en
    end

    private

    def load_translations_from(base_path)
      if I18n.load_path.empty?
        I18n.config.enforce_available_locales = false
        I18n.load_path = i18n_load_path_from(base_path)
        I18n.backend.load_translations
      end
    end

    def i18n_load_path_from(base_path)
      Dir[
        File.join(
          Pathname.new(base_path).parent,
          'locale',
          '*.yml')
      ]
      .flatten
      .uniq
    end

    def t(key, params = {})
      I18n.locale = locale
      prefix = /\/([^\/]+)\.mustache/.match(template_file)[1]
      params.merge! :default => key unless params[:default]
      translation = I18n.translate("#{prefix}.#{key}", params)
    end

    def template
      @template_string ||= File.open(template_file).read
    end

    def template_name
      Mustache.underscore(self.class.to_s).split('/').last
    end

    def template_file
      File.join(base_path,'templates',"#{template_name}.#{template_extension}")
    end

    def base_path
      self.class.base_path
    end

    def self.inherited(subclass)
      current_dir = File.dirname(caller.first[/^[^:]+/])
      dir_path = Pathname.new(File.join(current_dir,'..')).realdirpath

      subclass.base_path = dir_path.to_s

      Alephant::Publisher::Views.register(subclass)
    end
  end
end

