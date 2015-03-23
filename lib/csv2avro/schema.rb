class CSV2Avro
  class Schema
    attr_reader :avro_schema, :schema_io

    def initialize(schema_io)
      @schema_io = schema_io
      @avro_schema = Avro::Schema.parse(schema_io)
    end

    def defaults_hash
      Hash[
        avro_schema.fields.map{ |field| [field.name, field.default] unless field.default.nil? }.compact
      ]
    end

    def types_hash
      Hash[
        avro_schema.fields.map do |field|
          type = if field.type.type_sym == :union
            # use the primary type
            field.type.schemas[0].type_sym
          else
            field.type.type_sym
          end

          [field.name, type]
        end
      ]
    end

    # TODO: Change this when the avro gem starts to support aliases
    def aliases_hash
      schema_string = if schema_io.is_a?(StringIO)
        schema_io.string
      else
        schema_io.rewind
        schema_io.read
      end

      schema_as_json = JSON.parse(schema_string)

      Hash[
        schema_as_json['fields'].select{ |field| field['aliases'] }.flat_map do |field|
          field['aliases'].map { |one_alias| [one_alias, field['name']]}
        end
      ]
    end
  end
end
