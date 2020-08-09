require_relative 'setup'

RSpec.describe XPool do 
  let(:pool_size) do 
    2 
  end 

  let(:pool) do 
    XPool.new pool_size 
  end 

  after do 
    pool.shutdown!
  end

  describe '#broadcast' do 
    it 'broadcasts a job across a pool' do 
      child_processes = pool.broadcast Sleeper.new(1)
      child_processes.each { |process| expect(process.run_count).to eq(1) }
    end 
  end

  describe '#size' do 
    it 'returns the number of processes in a pool' do 
      expect(pool.size).to eq(pool_size)
    end 
  end 

  describe '#shutdown' do 
    it 'allows jobs to finish before clearing the queue' do 
      pool.resize!(1)
      writers = Array.new(pool_size) { IOWriter.new }
      writers.each { |writer| pool.schedule writer }
      pool.shutdown
      writers.each { |writer| expect(writer.wrote_to_disk?).to eq(true) }
    end
  end 

  describe '#schedule' do 
    it 'distrubutes a job across the pool' do 
      child_proccesses = Array.new(pool_size) { pool.schedule Sleeper.new(0.1) }
      child_proccesses.each { |subprocess| expect(subprocess.run_count).to eq(1) }
    end
  end

  describe '#resize!' do 
    it 'resizes the pool to the given number' do
      pool.resize!(1)
      expect(pool.size).to eq(1)
    end 
  end 

  describe '#expand' do 
    it 'expands the pool size by 1' do 
      pool.expand(1)
      expect(pool.size).to eq(pool_size + 1)
    end
  end

  describe '#shrink' do
    it 'shrinks the pool size by 1 (graceful shutdown)' do 
      pool.shrink(1)
      expect(pool.size).to eq(pool_size - 1)
    end 

    it 'raises an ArgumentError when shrink goes out of bounds' do 
      expect {
        pool.shrink! pool_size + 1
      }.to raise_error(ArgumentError)
    end 
  end
end
