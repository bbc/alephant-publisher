module MyApp
  class Bar < Alephant::Publisher::Views::Html
    def content
      @data[:content]
    end
  end
end
