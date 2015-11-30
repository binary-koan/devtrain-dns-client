require "spec_helper"

describe DNSQueryParser do
  describe "#parse" do
    subject(:query) { DNSQueryParser.new(data).parse }

    context "with a single A record" do
      let(:data) do
        "\x00\x03\x85\x00\x00\x01\x00\x01\x00\x04\x00\x00".force_encoding("ASCII-8BIT") + # header
        "\tpowershop\x02co\x02nz\x00\x00\x01\x00\x01".force_encoding("ASCII-8BIT") + # question
        "\xC0\f\x00\x01\x00\x01\x00\x00\x01,\x00\x04\xCB\xAB\"\xD3".force_encoding("ASCII-8BIT") + # answers
        "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x17\ans-1523\tawsdns-62\x03org\x00".force_encoding("ASCII-8BIT") + # dns (or something)
        "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x19\ans-1759\tawsdns-27\x02co\x02uk\x00".force_encoding("ASCII-8BIT") +
        "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x15\x05ns-41\tawsdns-05\x03com\x00".force_encoding("ASCII-8BIT") +
        "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x16\x06ns-836\tawsdns-40\x03net\x00".force_encoding("ASCII-8BIT")
      end

      it "assigns the ID correctly" do
        expect(query.id).to eq 3
      end

      it "parses questions" do
        expect(query.questions).to contain_exactly({ domain: "powershop.co.nz", type: "A" })
      end

      it "parses answers" do
        expect(query.answers).to contain_exactly({ domain: "powershop.co.nz", type: "A", response: "203.171.34.211" })
      end
    end
  end
end
