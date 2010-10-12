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

      @move = Move.new
      @game = Game.create(:moves => [@move])
    end

    it "runs callbacks for save of parent" do
      @move.history.should == [:before_save, :before_create, :after_create, :after_save]
    end

    it "runs callbacks for update of parent" do
      @move.clear_history
      @game.save
      @move.history.should == [:before_save, :before_update, :after_update, :after_save]
    end

    it "runs callbacks for destroy of parent" do
      @move.clear_history
      @game.destroy
      @move.history.should == [:before_destroy, :after_destroy]
    end

    it "does not attempt to run callback defined on parent that is not defined on embedded" do
      Game.define_callbacks :win
      @move.clear_history

      lambda do
        @game.run_callbacks(:win)
        @move.history.should be_empty
      end.should_not raise_error
    end

    it "runs create callback when saving new embbeded doc on existing parent" do
      @game.save
      move = Move.new
      @game.moves << move
      @game.save
      move.history.should == [:before_save, :before_create, :after_create, :after_save]
    end
  end
end