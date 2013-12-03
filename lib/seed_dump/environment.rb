class SeedDump
  module Environment

    def dump_using_environment(env)
      Rails.application.eager_load!

      SeedDump.dump(Sample,
                    append: (env['APPEND'] == 'true'),
                    create_method: env['CREATE_METHOD'],
                    exclude_attributes: (env['EXCLUDE'] ? env['EXCLUDE'].split(',').map {|e| e.strip.to_sym} : nil),
                    file: (env['FILE'] || 'db/seeds.rb'))
    end
  end
end

