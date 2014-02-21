module MyApp
  class Foo < ::Alephant::Views::Base
    def content
      @data[:content]
    end
  end
end
