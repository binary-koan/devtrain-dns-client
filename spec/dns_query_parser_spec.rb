require "spec_helper"

describe DNSQueryParser do
  def ascii_data(*data)
    data.join("").force_encoding("ASCII-8BIT")
  end

  describe "#parse" do
    subject(:query) { DNSQueryParser.new(data).parse }

    context "with a single A record" do
      let(:data) do
        ascii_data(
          "\x00\x03\x85\x00\x00\x01\x00\x01\x00\x04\x00\x00", # header
          "\tpowershop\x02co\x02nz\x00\x00\x01\x00\x01", # question
          "\xC0\f\x00\x01\x00\x01\x00\x00\x01,\x00\x04\xCB\xAB\"\xD3", # answers
          "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x17\ans-1523\tawsdns-62\x03org\x00", # extras
          "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x19\ans-1759\tawsdns-27\x02co\x02uk\x00",
          "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x15\x05ns-41\tawsdns-05\x03com\x00",
          "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x16\x06ns-836\tawsdns-40\x03net\x00"
        )
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

    context "with multiple MX records" do
      let(:data) do
        ascii_data(
          "\x00\x03\x85\x00\x00\x01\x00\a\x00\x04\x00\x00",
          "\tpowershop\x02co\x02nz\x00\x00\x0F\x00\x01",
          "\xC0\f\x00\x0F\x00\x01\x00\x00\x01,\x00\x16\x00\n\x05aspmx\x01l\x06google\x03com\x00", # answers
          "\xC0\f\x00\x0F\x00\x01\x00\x00\x01,\x00\t\x00\x14\x04alt1\xC0/",
          "\xC0\f\x00\x0F\x00\x01\x00\x00\x01,\x00\t\x00\x14\x04alt2\xC0/",
          "\xC0\f\x00\x0F\x00\x01\x00\x00\x01,\x00\x16\x00\x1E\x06aspmx2\ngooglemail\xC0>",
          "\xC0\f\x00\x0F\x00\x01\x00\x00\x01,\x00\v\x00\x1E\x06aspmx3\xC0\x82",
          "\xC0\f\x00\x0F\x00\x01\x00\x00\x01,\x00\v\x00\x1E\x06aspmx4\xC0\x82",
          "\xC0\f\x00\x0F\x00\x01\x00\x00\x01,\x00\v\x00\x1E\x06aspmx5\xC0\x82",
          "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x17\ans-1523\tawsdns-62\x03org\x00", # extras
          "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x19\ans-1759\tawsdns-27\x02co\x02uk\x00",
          "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x12\x05ns-41\tawsdns-05\xC0>",
          "\xC0\f\x00\x02\x00\x01\x00\x01Q\x80\x00\x16\x06ns-836\tawsdns-40\x03net\x00"
        )
      end

      it "finds all answers" do
        expect(query.answers.size).to eq 7
      end

      it "parses answers" do
        expect(query.answers.first).to eq({ domain: "powershop.co.nz", type: "MX", response: "10 aspmx.l.google.com"})
        expect(query.answers.last).to eq({ domain: "powershop.co.nz", type: "MX", response: "30 aspmx5.googlemail.com"})
      end
    end
  end
end
