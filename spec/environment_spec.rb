require 'spec_helper'

describe SeedDump do
  describe '#dump_using_environment' do
    before(:all) do
      create_db
    end

    before(:each) do
      ActiveSupport::DescendantsTracker.clear
    end

    describe 'APPEND' do
      it "should specify append as true if the APPEND env var is 'true'" do
        SeedDump.should_receive(:dump).with(anything, include(append: true))

        SeedDump.dump_using_environment('APPEND' => 'true')
      end

      it "should specify append as false if the APPEND env var is not 'true'" do
        SeedDump.should_receive(:dump).with(anything, include(append: false))

        SeedDump.dump_using_environment('APPEND' => 'false')
      end
    end

    describe 'CREATE_METHOD' do
      it 'should pass along a create method if one is specified' do
        SeedDump.should_receive(:dump).with(anything, include(create_method: 'save'))

        SeedDump.dump_using_environment('CREATE_METHOD' => 'save')
      end
    end

    describe 'EXCLUDE' do
      it 'should pass along any attributes to be excluded' do
        SeedDump.should_receive(:dump).with(anything, include(exclude_attributes: [:baggins, :saggins]))

        SeedDump.dump_using_environment('EXCLUDE' => 'baggins,saggins')
      end
    end

    describe 'FILE' do
      it 'should pass the FILE parameter to the dump method correctly' do
        SeedDump.should_receive(:dump).with(anything, include(file: 'blargle'))

        SeedDump.dump_using_environment('FILE' => 'blargle')
      end

      it 'should pass db/seeds.rb as the file parameter if no FILE is specified' do
        SeedDump.should_receive(:dump).with(anything, include(file: 'db/seeds.rb'))

        SeedDump.dump_using_environment({})
      end
    end
   end
 end
