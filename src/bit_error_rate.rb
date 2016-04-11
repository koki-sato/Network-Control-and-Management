# -*- coding: utf-8 -*-
include Math
require 'gnuplot'

class Baseband
  #= 同相成分を返すメソッド
  def get_i(n)
    return @baseband_i[n]
  end

  #= 直交成分を返すメソッド
  def get_q(n)
    return @baseband_q[n]
  end

  #= 自然符号化を適用時のQPSK変調
  def create_baseband_nature(n, data_sequences)
    @baseband_i = Array.new
    @baseband_q = Array.new

    n.times do |i|
      data_sequence = "#{data_sequences[2*i].to_s}#{data_sequences[2*i+1].to_s}"
      if data_sequence == "00"
        @baseband_i.push(1/sqrt(2))
        @baseband_q.push(1/sqrt(2))
      elsif data_sequence == "10"
        @baseband_i.push(-1/sqrt(2))
        @baseband_q.push(1/sqrt(2))
      elsif data_sequence == "11"
        @baseband_i.push(-1/sqrt(2))
        @baseband_q.push(-1/sqrt(2))
      elsif data_sequence == "01"
        @baseband_i.push(1/sqrt(2))
        @baseband_q.push(-1/sqrt(2))
      end
    end
  end

  #= グレイ符号化を適用時のQPSK変調
  def create_baseband_gray(n, data_sequences)
    @baseband_i = Array.new
    @baseband_q = Array.new

    n.times do |i|
      data_sequence = "#{data_sequences[2*i].to_s}#{data_sequences[2*i+1].to_s}"
      if data_sequence == "00"
        @baseband_i.push(1/sqrt(2))
        @baseband_q.push(1/sqrt(2))
      elsif data_sequence == "11"
        @baseband_i.push(-1/sqrt(2))
        @baseband_q.push(1/sqrt(2))
      elsif data_sequence == "10"
        @baseband_i.push(-1/sqrt(2))
        @baseband_q.push(-1/sqrt(2))
      elsif data_sequence == "01"
        @baseband_i.push(1/sqrt(2))
        @baseband_q.push(-1/sqrt(2))
      end
    end
  end

  #= 雑音の影響が重畳された信号
  def superimposed_noise(n, variance)
    n.times do |i|
      u1 = rand
      u2 = rand
      @baseband_i[i] = @baseband_i[i] + sqrt(-2.0*log(u1))*sqrt(variance)*cos(2*PI*u2)
      @baseband_q[i] = @baseband_q[i] + sqrt(-2.0*log(u1))*sqrt(variance)*sin(2*PI*u2)
    end
  end
end

class BitErrorRate
  #= 送信シンボル数
  TRANS_SYMBOL = 1000000

  #= データ値の生成
  def self.create_data_sequence(n)
    @@data_sequences = Array.new
    n.times do |i|
      @@data_sequences.push([0, 1].sample)
    end
  end

  #= ビット誤り率の取得
  def self.get_bit_error_rate
    create_data_sequence(TRANS_SYMBOL*2)
    baseband_1 = Baseband.new
    baseband_1.create_baseband_nature(TRANS_SYMBOL, @@data_sequences)
    baseband_2 = Baseband.new
    baseband_2.create_baseband_gray(TRANS_SYMBOL, @@data_sequences)
    @@bit_error_rate_1 = Array.new
    @@bit_error_rate_2 = Array.new
    0.upto(10) do |i|
      variance = (10 ** (-i.to_f / 10)) / 2
      count_error_1 = 0
      count_error_2 = 0
      (TRANS_SYMBOL).times do |n|
        u1 = rand
        u2 = rand
        noised_baseband_1_i = baseband_1.get_i(n) + sqrt(-2.0*log(u1))*sqrt(variance)*cos(2*PI*u2)
        noised_baseband_1_q = baseband_1.get_q(n) + sqrt(-2.0*log(u1))*sqrt(variance)*sin(2*PI*u2)
        noised_baseband_2_i = baseband_2.get_i(n) + sqrt(-2.0*log(u1))*sqrt(variance)*cos(2*PI*u2)
        noised_baseband_2_q = baseband_2.get_q(n) + sqrt(-2.0*log(u1))*sqrt(variance)*sin(2*PI*u2)
        if baseband_1.get_i(n) * noised_baseband_1_i < 0
          if baseband_1.get_q(n) * noised_baseband_1_q < 0
            count_error_1 = count_error_1 + 1
          else
            count_error_1 = count_error_1 + 2
          end
        end
        if baseband_2.get_i(n) * noised_baseband_2_i < 0
          if baseband_2.get_q(n) * noised_baseband_2_q < 0
            count_error_2 = count_error_2 + 2
          else
            count_error_2 = count_error_2 + 1
          end
        end
      end
      @@bit_error_rate_1.push(count_error_1.to_f / (TRANS_SYMBOL * 2))
      @@bit_error_rate_2.push(count_error_2.to_f / (TRANS_SYMBOL * 2))
    end

    @@bit_error_rate_1.each_with_index do |bit_error_rate_1, i|
      puts "nature #{i}: #{bit_error_rate_1}"
    end

    @@bit_error_rate_2.each_with_index do |bit_error_rate_2, i|
      puts "gray #{i}: #{bit_error_rate_2}"
    end
  end

  #= ビット誤り率特性を描画
  def self.draw_bit_error_rate
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        plot.title  "BitErrorRate"
        plot.set "logscale y"
        #= 自然符号化
        x = (0..10).collect {|v| v.to_i}
        y = @@bit_error_rate_1
        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "points"
          ds.title = "nature coding"
        end
        #= グレイ符号化
        x = (0..10).collect {|v| v.to_i}
        y = @@bit_error_rate_2
        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "points"
          ds.title = "gray coding"
        end
      end
    end
  end
end

BitErrorRate.get_bit_error_rate
BitErrorRate.draw_bit_error_rate
