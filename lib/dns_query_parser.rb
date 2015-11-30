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

    @offset = 12
    parse_questions(data, question_count)
    parse_answers(data, question_count)

    @result
  end

  private

  def parse_questions(data, count)
    @result.questions = count.times.map do
      domain_name = parse_domain_name
      @offset += 4

      domain_name
    end
  end

  def parse_answers(data, count)
    @result.answers = count.times.map do
      domain_name = parse_domain_name
      read(8)
      rdlength = read_short
      rdata = data[@offset, rdlength].unpack("CCCC")

      { domain_name: domain_name, address: rdata }
    end
  end

  def parse_domain_name(offset: @offset)
    if (data[offset].ord & 0xc0) == 0xc0
      domain_name_offset = data[offset, 2].unpack("n")[0] ^ 0xc000

      new_offset = offset + 2
      name, _ = parse_domain_name(offset: domain_name_offset)
      @offset = new_offset

      return name
    end

    parts = []

    while true
      next_length = data[offset].ord
      offset += 1
      break if next_length == 0

      parts << data[offset, next_length]
      offset += next_length
    end

    @offset = offset
    parts.join(".")
  end

  def read(bytes)
    @offset += bytes
    data[@offset - bytes, bytes]
  end

  def read_short
    read(2).unpack("n")[0]
  end
end
