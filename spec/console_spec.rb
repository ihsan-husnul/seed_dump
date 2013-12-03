require 'spec_helper'

describe SeedDump do

  describe '.dump' do
    before do
      Rails.application.eager_load!

      create_db

      3.times { FactoryGirl.create(:sample) }

      @expected_output = "Sample.create!([{string: \"string\", text: \"text\", integer: 42, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false},\n                {string: \"string\", text: \"text\", integer: 42, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false},\n                {string: \"string\", text: \"text\", integer: 42, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false}])\n"
    end

    context 'without file option' do
      it 'should return the dump of the models passed in' do
        SeedDump.dump(Sample).should eq(@expected_output)
      end
    end

    context 'with file option' do
      before do
        @filename = Dir::Tmpname.make_tmpname(File.join(Dir.tmpdir, 'foo'), nil)
      end

      after do
        File.unlink(@filename)
      end

      it 'should dump the models to the specified file' do
        SeedDump.dump(Sample, file: @filename)

        File.open(@filename) { |file| file.read.should eq(@expected_output) }
      end

      context 'with append option' do
        it 'should append to the file rather than overwriting it' do
          SeedDump.dump(Sample, file: @filename)
          SeedDump.dump(Sample, file: @filename, append: true)

          File.open(@filename) { |file| file.read.should eq(@expected_output + @expected_output) }
        end
      end
    end

    context 'with an order parameter' do
      it 'should dump the models in the specified order' do
        Sample.delete_all
        samples = 3.times {|i| FactoryGirl.create(:sample, integer: i) }

        SeedDump.dump(Sample.order('integer DESC')).should eq("Sample.create!([{string: \"string\", text: \"text\", integer: 2, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false},\n                {string: \"string\", text: \"text\", integer: 1, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false},\n                {string: \"string\", text: \"text\", integer: 0, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false}])\n")
      end
    end

    context 'without an order parameter' do
      it 'should dump the models sorted by primary key ascending' do
        Sample.delete_all
        samples = 3.times {|i| FactoryGirl.create(:sample, integer: i) }

        SeedDump.dump(Sample).should eq("Sample.create!([{string: \"string\", text: \"text\", integer: 0, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false},\n                {string: \"string\", text: \"text\", integer: 1, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false},\n                {string: \"string\", text: \"text\", integer: 2, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false}])\n")
      end
    end

    context 'with a limit parameter' do
      it 'should dump the number of models specified by the limit' do
        expected_output = "Sample.create!([{string: \"string\", text: \"text\", integer: 42, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false}])\n"

        SeedDump.dump(Sample.limit(1)).should eq(expected_output)
      end
    end

    context 'with a batch_size parameter' do
      it 'should not raise an exception' do

        SeedDump.dump(Sample, batch_size: 100)
      end
    end

    context 'with an array' do
      it 'should return the dump of the models passed in' do
        SeedDump.dump(Sample.all.to_a, batch_size: 2).should eq(@expected_output)
      end

      it 'should return nil if the array is empty' do
        SeedDump.dump([]).should be(nil)
      end
    end

    context 'with an exclude_attributes parameter' do
      it 'should exclude the specified attributes from the dump' do
        expected_output = "Sample.create!([{text: \"text\", integer: 42, decimal: \"2.72\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false},\n                {text: \"text\", integer: 42, decimal: \"2.72\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false},\n                {text: \"text\", integer: 42, decimal: \"2.72\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false}])\n"

        SeedDump.dump(Sample, exclude_attributes: [:id, :created_at, :updated_at,
                                                   :string, :float, :datetime]).should eq(expected_output)
      end
    end

    context 'with :create_method option' do
      it 'should use the specified create method' do
        expected_output = "Sample.create([{string: \"string\", text: \"text\", integer: 42, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false},\n                {string: \"string\", text: \"text\", integer: 42, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false},\n                {string: \"string\", text: \"text\", integer: 42, float: 3.14, decimal: \"2.72\", datetime: \"1776-07-04 19:14:00\", time: \"2000-01-01 03:15:00\", date: \"1863-11-19\", binary: \"binary\", boolean: false}])\n"

        SeedDump.dump(Sample, create_method: 'create').should eq(expected_output)
      end
    end
  end
end
