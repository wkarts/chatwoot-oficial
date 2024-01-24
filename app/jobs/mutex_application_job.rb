# MutexApplicationJob serves as a base class for jobs that require distributed locking mechanisms.
# It abstracts the locking logic using Redis and ensures that a block of code can be executed with
# mutual exclusion.
#
# The primary mechanism provided is the `with_lock` method, which accepts a key format and associated
# arguments. This method attempts to acquire a lock using the generated key, and if successful, it
# executes the provided block of code. If the lock cannot be acquired, it raises a LockAcquisitionError.
#
# To use this class, inherit from MutexApplicationJob and make use of the `with_lock` method in the
# `perform` method of the derived job class.
#
# Also see, retry mechanism here: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
#
class MutexApplicationJob < ApplicationJob
  class LockAcquisitionError < StandardError; end

  def with_lock(lock_key, timeout = 1.second)
    lock_manager = Redis::LockManager.new

    begin
      if lock_manager.lock(lock_key, timeout)
        Rails.logger.info "[#{self.class.name}] Acquired lock for: #{lock_key} on attempt #{executions}"
        yield
        # release the lock after the block has been executed
        lock_manager.unlock(lock_key)
      else
        Rails.logger.warn "[#{self.class.name}] Failed to acquire lock on attempt #{executions}: #{lock_key}"
        raise LockAcquisitionError, "Failed to acquire lock for key: #{lock_key}"
      end
    rescue StandardError => e
      lock_manager.unlock(lock_key) unless e.is_a?(LockAcquisitionError)
      raise e
    end
  end
end
