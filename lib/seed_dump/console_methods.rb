class SeedDump
  module ConsoleMethods
    include Enumeration

    def dump(records, options = {})
      return nil if records.count == 0

      io = open_io(options)

      write_records_to_io(records, io, options)

      ensure
        io.close if io.present?
    end

    private

    def dump_record(record, options)
      attribute_strings = []

      options[:exclude_attributes] ||= [:id, :created_at, :updated_at]

      # We select only string attribute names to avoid conflict
      # with the composite_primary_keys gem (it returns composite
      # primary key attribute names as hashes).
      record.attributes.select {|key| key.is_a?(String) }.each do |attribute, value|
        attribute_strings << dump_attribute_new(attribute, value) unless options[:exclude_attributes].include?(attribute.to_sym)
      end

      "{#{attribute_strings.join(", ")}}"
    end

    def dump_attribute_new(attribute, value)
      "#{attribute}: #{value_to_s(value)}"
    end

    def value_to_s(value)
      value = case value
              when BigDecimal
                value.to_s
              when Date, Time, DateTime
                value.to_s(:db)
              else
                value
              end

      value.inspect
    end

    def open_io(options)
      if options[:file].present?
        mode = options[:append] ? 'a+' : 'w+'

        File.open(options[:file], mode)
      else
        StringIO.new('', 'w+')
      end
    end

    def write_records_to_io(records, io, options)
      io.write("#{model_for(records)}.#{options[:create_method] || 'create!'}([")

      enumeration_method = if records.is_a?(ActiveRecord::Relation) || records.is_a?(Class)
                             :active_record_enumeration
                           else
                             :enumerable_enumeration
                           end

      send(enumeration_method, records, io, options) do |record_strings, batch_number, last_batch_number|
        io.write("#{record_strings.join(",\n" + (' ' * 16))}")

        io.write(",\n#{' ' * 16}") if batch_number != last_batch_number
      end

      io.write("])\n")

      if options[:file].present?
        nil
      else
        io.rewind
        io.read
      end
    end

    def model_for(records)
      if records.is_a?(Class)
        records
      elsif records.respond_to?(:model)
        records.model
      else
        records[0].class
      end
    end

  end
end
