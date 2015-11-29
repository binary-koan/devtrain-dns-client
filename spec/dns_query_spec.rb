require "spec_helper"

describe DNSQuery do
  describe "#id" do
    it "becomes the first 16 bits in the header" do
      header = DNSQuery.new(123)
      expect(header.build.unpack("n")[0]).to eq 123
    end
  end

  describe "#add_question" do
    let(:query) { DNSQuery.new(234) }
    before { query.add_question("google.com") }

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
    before { query.add_question(domain_name) }

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
end
