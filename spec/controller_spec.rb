require "spec_helper"

class SmoochUser
  USER_ID = 42
  def id
    USER_ID
  end
end
class SmoochController < ActionController::Base
  def get_km
    @results = km
  end
  def get_identity
    @results = smooch_identity
  end
end

ActionController::Routing::Routes.draw do |map|
  map.connect "smooch/:action", :controller => "smooch"
end

describe SmoochController, :type => :controller do

  context "when called kiss with no inputs" do
    before(:each) do
      SmoochController.class_eval do
        kiss
      end
    end  
    
    describe "#smooch_identity" do
      it "should set a random cookie" do
        cookies[Smooch::COOKIE_ID].should be_nil
        get :get_identity
        cookies[Smooch::COOKIE_ID].should_not be_blank
      end
      it "should not change the cookie" do
        cookies[Smooch::COOKIE_ID] = "nice!"
        get :get_identity
        cookies[Smooch::COOKIE_ID].should == "nice!"
      end
    end
    
    describe "#km" do
      it "should have a reference to the controller" do
        get :get_km
        assigns[:results].controller.should == @controller
      end
      
      it "should use controller to get cookie value" do
        cookies["whatever"] = "test!"
        get :get_km
        assigns[:results].get_cookie("whatever").should == "test!"
      end
    end
    
    describe "records" do
      it "should transfer flash property" do
        flash[:kiss_metrics] = "whatever"
        get :get_km
        assigns[:results].has_record?("whatever").should == true
      end
    end
  end
  
  context "when kiss called with black" do
    before(:each) do
      SmoochController.class_eval do
        def random_stuff
          "my_custom_value"
        end
        kiss { |controller| controller.random_stuff }
      end
    end
    describe "#smooch_identity" do
      it "should return custom value" do
        cookies[Smooch::COOKIE_ID].should be_nil
        get :get_identity
        assigns[:results].should == "my_custom_value"
        cookies[Smooch::COOKIE_ID].should be_nil
      end
    end
  end
    
  context "when kiss called with identity method" do
    before(:each) do
      SmoochController.class_eval do
        kiss :current_user
      end
    end
    
    describe "#smooch_identity" do
      context "when there is a current user" do
        before(:each) do
          SmoochController.class_eval do
            def current_user
              SmoochUser.new
            end
          end
        end
        it "should return the current user id" do
          cookies[Smooch::COOKIE_ID].should be_nil
          get :get_identity
          assigns[:results].should == SmoochUser::USER_ID
          cookies[Smooch::COOKIE_ID].should be_nil
        end
      end

      context "when there is no current user" do
        before(:each) do
          SmoochController.class_eval do
            def current_user
              nil
            end
          end
        end
        it "should set a random cookie" do
          cookies[Smooch::COOKIE_ID].should be_nil
          get :get_identity
          cookies[Smooch::COOKIE_ID].should_not be_blank
        end
      end
    end
  end
end