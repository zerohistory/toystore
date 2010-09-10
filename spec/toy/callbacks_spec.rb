require 'helper'

module CallbackHelper
  extend ActiveSupport::Concern

  included do
    [ :before_create,  :after_create,
      :before_update,  :after_update,
      :before_save,    :after_save,
      :before_destroy, :after_destroy].each do |callback|
      callback_method = "#{callback}_callback"
      send(callback, callback_method)
      define_method(callback_method) { history << callback.to_sym }
    end
  end

  def history
    @history ||= []
  end

  def clear_history
    @history = nil
  end
end

describe Toy::Callbacks do
  uses_constants('Game', 'Move')

  context "regular" do
    before do
      Game.send(:include, CallbackHelper)
    end

    it "runs callbacks in correct order for create" do
      doc = Game.create
      doc.history.should == [:before_save, :before_create, :after_create, :after_save]
    end

    it "runs callbacks in correct order for update" do
      doc = Game.create
      doc.clear_history
      doc.save
      doc.history.should == [:before_save, :before_update, :after_update, :after_save]
    end

    it "runs callbacks in correct order for destroy" do
      doc = Game.create
      doc.clear_history
      doc.destroy
      doc.history.should == [:before_destroy, :after_destroy]
    end
  end

  context "embedded" do
    before do
      Game.embedded_list(:moves)
      Move.send(:include, CallbackHelper)
    end

    xit "runs callbacks for save of parent" do
      move = Move.new
      game = Game.create(:moves => [move])
      move.history.should == [:before_save, :after_save]
    end
  end
end