module MyApp
  class Foo < Alephant::Publisher::Views::Html
    def content
      @data[:content]
    end
  end
end
