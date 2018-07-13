class Job < ApplicationRecord
  belongs_to :user
  has_many :splayd_selections
  has_many :splayds, :through => :splayd_selections

  validates_presence_of :bits, :endianness, :max_mem
  validates_presence_of :disk_max_size, :disk_max_files, :disk_max_file_descriptors
  validates_presence_of :network_max_send, :network_max_receive, :network_max_sockets
  validates_presence_of :network_nb_ports, :network_send_speed, :network_receive_speed
  validates_presence_of :code, :nb_splayds, :list_type, :strict, :list_size, :splayd_version

  validates_numericality_of :max_mem, :only_integer => true
  validates_numericality_of :disk_max_size, :disk_max_files, :disk_max_file_descriptors, :only_integer => true
  validates_numericality_of :network_max_send, :network_max_receive, :network_max_sockets, :only_integer => true
  validates_numericality_of :network_nb_ports, :network_send_speed, :network_receive_speed, :only_integer => true
  validates_numericality_of :nb_splayds, :list_size, :max_time, :min_uptime, :only_integer => true
  validates_numericality_of :max_load
end