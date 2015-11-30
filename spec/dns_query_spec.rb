require "spec_helper"

describe DNSQuery do
  describe "#id" do
    it "becomes the first 16 bits in the header" do
      header = DNSQuery.new(123)
      expect(header.build.unpack("n")[0]).to eq 123
    end
  end

  describe "#questions" do
    let(:query) { DNSQuery.new(234) }
    before { query.questions.push(domain: "google.com") }

    it "adds a body to the message" do
      expect(query.build.length).to eq 28
    end

    it "encodes the domain name with length values" do
      expect(query.build[12].ord).to eq 6
      expect(query.build[13..18]).to eq "google"

      expect(query.build[19].ord).to eq 3
      expect(query.build[20..22]).to eq "com"
    end
  end

  describe "#build" do
    let(:query) { DNSQuery.new(query_id) }
    before { query.questions.push(domain: domain_name) }

    context "with a query for google.com" do
      let(:query_id) { 3 }
      let(:domain_name) { "google.com" }

      let(:expected_response) do
        "\x00\x03\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x06google\x03com\x00\x00\x01\x00\x01".force_encoding("ASCII-8BIT")
      end

      it "returns the expected query" do
        expect(query.build).to eq expected_response
      end
    end
  end

  describe "#parse" do
    let(:data) do
      "\x00\x03\x85\x00\x00\x01\x00\x01\x00\x04\x00\x00".force_encoding("ASCII-8BIT") + # header
      "\tpowershop\x02co\x02nz\x00\x00\x01\x00\x01".force_encoding("ASCII-8BIT") + # question
      "\xC0\f\x00\x01\x00\x01\x00\x00\x01,\x00\x04\xCB\xAB\"\xD3".force_encoding("ASCII-8BIT") + # answers
      "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x17\ans-1523\tawsdns-62\x03org\x00".force_encoding("ASCII-8BIT") + # dns (or something)
      "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x19\ans-1759\tawsdns-27\x02co\x02uk\x00".force_encoding("ASCII-8BIT") +
      "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x15\x05ns-41\tawsdns-05\x03com\x00".force_encoding("ASCII-8BIT") +
      "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x16\x06ns-836\tawsdns-40\x03net\x00".force_encoding("ASCII-8BIT")
    end

    let(:query) { DNSQueryParser.new(data).parse }

    it "assigns the ID correctly" do
      expect(query.id).to eq 3
    end

    it "parses answers" do
      expect(query.answers).to contain_exactly({ :domain_name => "powershop.co.nz", :response => "203.171.34.211" })
    end
  end
end
