require File.dirname(__FILE__) + '/../spec_helper'

describe ErpTxnsAndAcctsController  do
  it "should redirect to the show actions" do
    get :index
    response.should render_template("index")
  end
end