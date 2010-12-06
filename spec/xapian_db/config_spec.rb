# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe XapianDb::Config do

  describe ".setup(&block)" do
    
    describe ".database" do
      it "accepts a in memory database" do
        XapianDb::Config.setup do |config|
          config.database :memory
        end
        XapianDb.database.should be_a_kind_of XapianDb::InMemoryDatabase
      end

      it "accepts a persistent database" do
        db_path = "/tmp/xapian_db"
        XapianDb::Config.setup do |config|
          config.database db_path
        end
        File.exist?(db_path).should be_true
        XapianDb.database.should be_a_kind_of XapianDb::PersistentDatabase
        FileUtils.rm_rf db_path
      end

      it "reopens the database if it already exists" do
        db_path = "/tmp/xapian_db"
        FileUtils.rm_rf db_path
        
        XapianDb::Config.setup do |config|
          config.database db_path
        end
        
        # Put a doc into the database
        doc = Xapian::Document.new
        XapianDb.database.store_doc(doc).should be_true
        
        # Now reopen the database
        XapianDb::Config.setup do |config|
          config.database db_path
        end
        XapianDb.database.size.should == 1 # The doc should still be there
      end

    end
  
    describe ".adapter" do
      it "accepts a generic adapter" do
        XapianDb::Config.setup do |config|
          config.adapter :generic
        end
        XapianDb::Config.adapter.should be_equal XapianDb::Adapters::GenericAdapter
      end

      it "accepts a datamapper adapter" do
        XapianDb::Config.setup do |config|
          config.adapter :datamapper
        end
        XapianDb::Config.adapter.should be_equal XapianDb::Adapters::DatamapperAdapter
      end

      it "accepts an active_record adapter" do
        XapianDb::Config.setup do |config|
          config.adapter :active_record
        end
        XapianDb::Config.adapter.should be_equal XapianDb::Adapters::ActiveRecordAdapter
      end

      it "raises an error if the configured adapter is unknown" do
        lambda{XapianDb::Config.setup do |config|
          config.adapter :unknown
        end}.should raise_error
      end
    end

    describe ".writer" do
      it "accepts a direct writer" do
        XapianDb::Config.setup do |config|
          config.writer :direct
        end
        XapianDb::Config.writer.should be_equal XapianDb::IndexWriters::DirectWriter
      end

      it "raises an error if the configured writer is unknown" do
        lambda{XapianDb::Config.setup do |config|
          config.writer :unknown
        end}.should raise_error
      end

    end    
  end
  
end