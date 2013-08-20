# encoding : utf-8
require 'spec_helper'

describe WorkerManager do
  let(:workers_count) { 5 }
  let!(:worker) { double(Worker) }

  before do
    Worker.stub(:new).and_return(worker)
  end

  subject { described_class.new(workers_count) }

  describe ".new" do
    after { subject }
    it { expect(subject.pids.size).to eq workers_count }

    it "forks process workers_count times and does Worker.new for each" do
      Process.should_receive(:fork).exactly(workers_count).times do |&worker_block|
        Worker.should_receive(:new)
        worker_block.call
      end
    end
  end
end