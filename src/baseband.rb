# -*- coding: utf-8 -*-
include Math
require 'gnuplot'

class Baseband
  #= 送信シンボル数
  TRANS_SYMBOL = 30

  #= データ値の生成
  def create_data_sequence(n)
    @data_sequences = Array.new
    n.times do |i|
      @data_sequences.push([0, 1].sample)
    end
  end

  #= 自然符号化を適用時のQPSK変調
  def create_baseband_nature(n)
    @baseband_i = Array.new
    @baseband_q = Array.new
    create_data_sequence(2*n)

    n.times do |i|
      data_sequence = "#{@data_sequences[2*i].to_s}#{@data_sequences[2*i+1].to_s}"
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
  def create_baseband_gray(n)
    @baseband_i = Array.new
    @baseband_q = Array.new
    create_data_sequence(2*n)

    n.times do |i|
      data_sequence = "#{@data_sequences[2*i].to_s}#{@data_sequences[2*i+1].to_s}"
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

  #= 同相成分/直交成分の描画
  def draw_baseband(title)
    draw_baseband_i(title)
    draw_baseband_q(title)
  end

  #= 同相成分の描画
  def draw_baseband_i(title)
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        plot.title  "Baseband (In-phase) #{title}"
        x = (1..@baseband_i.length).collect {|v| v.to_i}
        y = @baseband_i
        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "impulses"
          ds.notitle
        end
      end
    end
  end

  #= 直交成分の描画
  def draw_baseband_q(title)
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        plot.title  "Baseband (Quadrature-phase) #{title}"
        x = (1..@baseband_q.length).collect {|v| v.to_i}
        y = @baseband_q
        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "impulses"
          ds.notitle
        end
      end
    end
  end

  #= (3)用
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

#= (1)用
#= 自然符号
baseband_1 = Baseband.new
baseband_1.create_baseband_nature(Baseband::TRANS_SYMBOL)
baseband_1.draw_baseband("natural coding")
#= グレイ符号
baseband_2 = Baseband.new
baseband_2.create_baseband_gray(Baseband::TRANS_SYMBOL)
baseband_2.draw_baseband("gray coding")

#= (3)用
#= CNRから分散を取得
variance_1 = (10 ** (0 / 10)).to_f / 2
variance_2 = (10 ** (-10 / 10)).to_f / 2

#= 自然符号/CNR=0
baseband_3 = baseband_1
baseband_3.superimposed_noise(Baseband::TRANS_SYMBOL, variance_1)
baseband_3.draw_baseband("natural coding")
#= グレイ符号/CNR=0
baseband_4 = baseband_2
baseband_4.superimposed_noise(Baseband::TRANS_SYMBOL, variance_1)
baseband_4.draw_baseband("gray coding")
#= 自然符号/CNR=10
baseband_5 = baseband_1
baseband_5.superimposed_noise(Baseband::TRANS_SYMBOL, variance_2)
baseband_5.draw_baseband("natural coding")
#= グレイ符号/CNR=10
baseband_6 = baseband_2
baseband_6.superimposed_noise(Baseband::TRANS_SYMBOL, variance_2)
baseband_6.draw_baseband("gray coding")
