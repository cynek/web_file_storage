# encoding : utf-8
require 'spec_helper'

describe WorkerManager do
  let(:workers_count) { 1 }
  let(:epoll) { double(SP::Epoll, :add => true) }
  let(:master_socket) { double(Socket) }
  let(:worker_socket) { double(Socket) }
  let(:worker_reader) { double(WorkerReader) }
  let(:worker_writer) { double(WorkerWriter) }
  let(:pid) { 666 }

  before do
    SP::Epoll.stub(:new).and_return(epoll)
    Socket.stub(:pair).and_return([master_socket, worker_socket])
    Process.stub(:fork).and_return(pid)
    WorkerWriter.stub(:new).and_return(worker_writer)
  end

  subject { described_class.new(workers_count) }

  describe ".new" do
    after { subject }

    it { epoll.should_receive(:add).with(worker_socket, SP::Epoll::IN | SP::Epoll::ET) }

    it "forks process workers_count times and does Worker.new for each" do
      Process.should_receive(:fork).exactly(workers_count).times do |&worker_block|
        master_socket.should_receive(:close)
        WorkerReader.should_receive(:new).with(worker_socket)
        worker_block.call
      end
    end

    it { expect(subject.workers).to include(worker_writer) }
    it { expect(subject.workers.size).to eq workers_count }

    it { expect(subject.epoll).to eq epoll }
  end

end