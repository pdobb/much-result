require "much-result"

class MuchResult; end
class MuchResult::Transaction
  def self.halt_throw_value
    :muchresult_transaction_halt
  end

  def self.call(receiver, **result_kargs, &block)
    new(receiver, **result_kargs).call(&block)
  end

  def initialize(receiver, **result_kargs)
    @receiver = receiver
    @result_kargs = result_kargs
  end

  def result
    @result ||= MuchResult.success(**@result_kargs)
  end

  def call(&block)
    begin
      @receiver.transaction do
        catch(self.class.halt_throw_value) { block.call(self) }
      end
    rescue MuchResult::Rollback
      # do nothing
    end

    result
  end

  def rollback
    raise MuchResult::Rollback
  end

  def halt
    throw(self.class.halt_throw_value)
  end

  private

  def respond_to_missing?(*args)
    result.send(:respond_to_missing?, *args)
  end

  def method_missing(method, *args, &block)
    result.public_send(method, *args, &block)
  end
end
