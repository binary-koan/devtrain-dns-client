class DNSQueryParser
  attr_reader :data

  def initialize(data)
    @data = data
    @offset = 0
    @result = DNSQuery.new
  end

  def parse
    @result.id = read_short
    read_short # flags
    question_count = read_short
    answer_count = read_short

    # skip the rest of the header
    @offset = 12

    parse_questions(data, question_count)
    parse_answers(data, answer_count)

    @result
  end

  private

  def parse_questions(data, count)
    @result.questions = count.times.map do
      domain_name = parse_domain_name
      type = DNSQuery::RECORD_TYPE.key(read_short)
      @offset += 2 # skip class

      { domain: domain_name, type: type }
    end
  end

  def parse_answers(data, count)
    @result.answers = count.times.map do
      domain_name = parse_domain_name
      type = DNSQuery::RECORD_TYPE.key(read_short)

      # Skip the rest of the answer header
      read(6)

      rdlength = read_short
      rdata = parse_response_data(type, read(rdlength))

      { domain: domain_name, type: type, response: rdata }
    end
  end

  def parse_response_data(type, data)
    case type
    when "A"
      data.unpack("CCCC").join(".")
    when "MX"
      priority = peek_short(data: data, offset: 0)
      domain = parse_domain_name(offset: 2, data: data, update_offset: false)
      "#{priority} #{domain}"
    else
      data
    end
  end

  def parse_domain_name(offset: @offset, data: @data, update_offset: true)
    return parse_compressed_domain_name(offset) if compressed_domain_name?(offset)

    parts = []
    while true
      next_length = data[offset].ord
      offset += 1
      break if next_length == 0

      parts << data[offset, next_length]
      offset += next_length
    end

    @offset = offset if update_offset
    parts.join(".")
  end

  def compressed_domain_name?(offset)
    (data[offset].ord & 0xc0) == 0xc0
  end

  def parse_compressed_domain_name(offset)
    domain_name_offset = peek_short(offset: offset) ^ 0xc000

    name, _ = parse_domain_name(offset: domain_name_offset)
    @offset = offset + 2

    name
  end

  def peek(bytes, data: @data, offset: @offset)
    data[offset, bytes]
  end

  def peek_short(data: @data, offset: @offset)
    peek(2, data: data, offset: offset).unpack("n")[0]
  end

  def read(bytes)
    @offset += bytes
    data[@offset - bytes, bytes]
  end

  def read_short
    read(2).unpack("n")[0]
  end
end
