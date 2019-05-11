require_relative 'setup'
RSpec.describe XPool::Process do 
  let(:process) do 
    XPool::Process.new
  end

  after do 
    process.shutdown!
  end

  describe '#frequency' do 
    it 'increments by 1 each time a job is scheduled' do
      4.times { process.schedule Sleeper.new(0.1) }
      expect(process.frequency).to eq(4)
    end
  end 

  describe '#shutdown' do
    it 'allows scheduled jobs to clear the queue before shutdown' do
      writers = Array.new(5) { IOWriter.new }
      writers.each { |writer| process.schedule writer }
      process.shutdown
      writers.each { |writer| expect(writer.wrote_to_disk?).to eq(true) } 
    end  
  end 
end
