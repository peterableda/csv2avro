require 'avro'

class CSV2Avro
  class AvroFile
    attr_reader :avro_io

    def initialize(schema_string, output)
      schema = Avro::Schema.parse(schema_string)
      writer = Avro::IO::DatumWriter.new(schema)

      @avro_io = Avro::DataFile::Writer.new(output, writer, schema)
    end

    def writer_schema
      avro_io.datum_writer.writers_schema
    end

    def io
      avro_io.encoder.writer
    end

    def write(hash)
      avro_io << hash
    end

    def flush
      avro_io.flush
    end

    def close
      avro_io.close
    end
  end
end
