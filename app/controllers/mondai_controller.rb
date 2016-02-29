class MondaiController < ApplicationController
  def index
    @mondais = [
      { :name  => "priclu",  :summary  => "プリクラ問題" },
    ]
  end
end
