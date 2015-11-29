require "spec_helper"

describe DNSQuery do
  describe "#id" do
    it "becomes the first 16 bits in the header" do
      header = DNSQuery.new(123)
      expect(header.build.unpack("S")[0]).to eq 123
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
end
