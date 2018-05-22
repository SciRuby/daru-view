describe Daru::View, "Update JS files" do
  context "command usage" do
    it "shows the command usage description" do
      flag = system('daru-view -h')
      expect(flag).to eq(true)
    end
  end

  context "googlecharts" do
    it "updates google charts javascript dependent files" do
      flag = system('daru-view -g')
      expect(flag).to eq(true)
    end
  end

  context "highcharts" do
    it "updates high charts javascript dependent files" do
      flag = system('daru-view -H')
      expect(flag).to eq(true)
    end
  end
end
