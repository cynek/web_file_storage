# encoding : utf-8
require 'spec_helper'

describe Master do
  let!(:manager) { double(WorkerManager, :work => true) }
  let!(:tcp_server) { double(WorkerManager, :accept => connection_socket) }
  let!(:connection_socket) { double(TCPSocket) }

  before do
    WorkerManager.stub(:new).and_return(manager)
    TCPServer.stub(:new).and_return(tcp_server)
  end

  describe ".new" do
    context "when without args" do
      after { described_class.new }
      it { WorkerManager.should_receive(:new).with(Master::WORKERS_COUNT) }
      it { TCPServer.should_receive(:new).with(Master::HOST, Master::PORT) }
    end

    context "when workers count sets" do
      after { described_class.new(5) }
      it { WorkerManager.should_receive(:new).with(5) }
    end
  end

  describe "#listen" do
    after { catch(:rspec_loop_stop) { subject.listen } }
    it "loops listen and send request to manger" do
      manager.should_receive(:work).with(connection_socket)
      manager.should_receive(:work).with(connection_socket)
      manager.should_receive(:work).and_throw(:rspec_loop_stop)
    end
  end
end