# -*- coding: utf-8 -*-
include Math
require 'gnuplot'

class Noise
  #= 雑音信号の生成
  def create_noise(n, variance)
    @noise_i = Array.new
    @noise_q = Array.new
    n.times do |i|
      u1 = rand
      u2 = rand
      @noise_i.push(sqrt(-2.0*log(u1))*sqrt(variance)*cos(2*PI*u2))
      @noise_q.push(sqrt(-2.0*log(u1))*sqrt(variance)*sin(2*PI*u2))
    end
  end

  #= 確率密度を取得
  def get_probability_density
    @probability_density_i = Array.new
    @probability_density_q = Array.new
    (-6).upto(5) do |n|
      10.times do |i|
        @probability_density_i.push(@noise_i.count {|n_i| n+i*0.1 <= n_i && n_i < n+(i+1)*0.1})
        @probability_density_q.push(@noise_q.count {|n_q| n+i*0.1 <= n_q && n_q < n+(i+1)*0.1})
      end
    end
  end

  #= 分散を取得
  def get_variance
    avg_i = @noise_i.inject(0.0) {|r,i| r += i } / @noise_i.size
    avg_q = @noise_q.inject(0.0) {|r,i| r += i } / @noise_q.size
    @variance_i = @noise_i.inject(0.0) {|r,i| r += (i-avg_i)**2 } / @noise_i.size
    @variance_q = @noise_q.inject(0.0) {|r,i| r += (i-avg_q)**2 } / @noise_q.size
    puts "I_phase: #{@variance_i}"
    puts "Q_phase: #{@variance_q}"
  end

  #= 同相成分/直交成分の描画
  def draw_noise
    draw_noise_i
    draw_noise_q
  end

  #= 同相成分の描画
  def draw_noise_i
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        plot.title  'Noise (In-phase)'
        x = (1..@noise_i.length).collect {|v| v.to_i}
        y = @noise_i
        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "impulses"
          ds.notitle
        end
      end
    end
  end

  #= 直交成分の描画
  def draw_noise_q
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        plot.title  'Noise (Quadrature-phase)'
        x = (1..@noise_q.length).collect {|v| v.to_i}
        y = @noise_q
        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "impulses"
          ds.notitle
        end
      end
    end
  end

  #= 同相成分/直交成分の確率密度の描画
  def draw_probability_density
    draw_probability_density_i
    draw_probability_density_q
  end

  #= 同相成分の確率密度の描画
  def draw_probability_density_i
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        plot.title  'Probability Density (In-phase)'
        x = (1..@probability_density_i.length).collect {|v| 12*v.to_f/@probability_density_i.length - 6}
        y = @probability_density_i
        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "linespoints"
          ds.notitle
        end
      end
    end
  end

  #= 直交成分の確率密度の描画
  def draw_probability_density_q
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        plot.title  'Probability Density (Quadrature-phase)'
        x = (1..@probability_density_q.length).collect {|v| 12*v.to_f/@probability_density_q.length - 6}
        y = @probability_density_q
        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "points"
          ds.notitle
        end
      end
    end
  end
end

noise = Noise.new
noise.create_noise(1000, 1)
noise.draw_noise
noise.create_noise(100000, 1)
noise.get_probability_density
noise.draw_probability_density
noise.get_variance
