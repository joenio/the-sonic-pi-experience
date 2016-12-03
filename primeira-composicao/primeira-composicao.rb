# Primeira composicao com Sonic Pi
#
# Autor: Joenio Costa
#
# Data de criação: 03 dezembro 2016
# Última alteração: 03 dezembro 2016
#
# Licença: GPLv3+

bateria_off = false

live_loop :bateria do
  unless bateria_off
    3.times do
      sample :drum_heavy_kick
      sleep 0.5
      sample :drum_snare_hard
      sleep 0.5
    end
    sample :drum_heavy_kick
    2.times do
      sleep 0.25
      sample :drum_snare_hard
      sample :drum_tom_lo_soft
      sleep 0.25
    end
  else
    # just wait 4 beats
    sleep 4
  end
end

define :virada do
  2.times do
    sample :drum_snare_hard
    sleep 0.25
  end
  in_thread do
    4.times do
      sample :drum_snare_hard
      sleep 0.25
    end
  end
  in_thread do
    sleep 0.125
    3.times do
      sample :drum_snare_hard
      sleep 0.125
    end
  end
  sleep 0.75
  sample :drum_tom_lo_soft
  sample :drum_tom_hi_soft
  sleep 0.5
  sample :drum_tom_lo_soft
  sample :drum_tom_mid_soft
  with_fx :echo, decay: 3, phase: 0.25 do
    with_fx :gverb, amp: 0.5, room: 15, release: 5 do
      sample :drum_snare_hard
    end
  end
  sleep 0.5
  sample :drum_tom_lo_soft
  sample :drum_tom_lo_hard
  2.times do
    sleep 0.25
    sample :drum_tom_lo_hard
    with_fx :echo, decay: 3, phase: 0.25 do
      with_fx :gverb, amp: 0.7, room: 15, release: 5 do
        sample :drum_snare_hard
      end
    end
  end
  sleep 0.5
  in_thread do
    4.times do
      sample :drum_snare_hard
      sleep 0.25
    end
  end
  in_thread do
    sleep 0.125
    3.times do
      sample :drum_snare_hard
      sleep 0.125
    end
  end
  4.times do
    sample :drum_snare_hard
    sleep 0.125
  end
  sleep 0.25
  2.times do
    with_fx :echo, decay: 3, phase: 0.25 do
      with_fx :gverb, amp: 0.5, room: 15, release: 5 do
        sample :drum_snare_hard
        sample :drum_snare_hard
      end
    end
    sleep 1
  end
end

define :teclado do |nota|
  use_synth :dsaw
  play "#{nota}2", decay: 0.4, release: 5, attack: 0.2, amp: 0.6
  play nota, decay: 0.3, release: 5, attack: 0.2, amp: 0.6
end

live_loop :chimbau do
  sync :bateria
  unless bateria_off
    13.times do
      sample :drum_cymbal_closed
      sleep 0.25
    end
    sample :drum_cymbal_closed, amp: 1.2
    sample :drum_cymbal_soft
    sleep 0.25
    sample :drum_cymbal_closed
    sleep 0.25
  else
    # just wait 4 beats
    sleep 3.75
  end
end

# sino
sino_c = 0
in_thread do
  sleep 6
  sync :bateria
  live_loop :sino do
    unless bateria_off
      if ((sino_c+=1) % 4).zero?
        4.times do
          sample :drum_cowbell
          sleep 1
        end
      else
        7.times do
          sample :drum_cowbell, amp: 0.8
          sleep 0.5
        end
        sleep 0.5
      end
    else
      # just wait 4 beats
      sleep 4
    end
  end
end

# teclado
notas = [:c, :d, :e]
aguarde = 16
in_thread do
  loop do
    sleep aguarde
    sync :bateria
    notas.each do |nota|
      teclado nota
      sleep 4
    end
    2.times do
      teclado notas.last
      with_fx :reverb do
        with_fx :distortion do
          sample :guit_e_fifths
        end
      end
      sleep 4
    end
    cue :guitarra
    aguarde = rrand(20, 40)
  end
end

c = 0
in_thread do
  sync :guitarra
  loop do
    n = rrand_i(1, 6)
    (n * 2).times do |step|
      with_fx :reverb do
        with_fx :distortion do
          sample :guit_e_fifths
        end
      end
      if bateria_off && step <= n
        in_thread do
          sync :bateria
          virada
        end
      elsif bateria_off && n > 2
        with_fx :ixi_techno do
          with_fx :band_eq do
            with_fx :flanger do
              with_fx :octaver do
                with_fx :reverb, room: 1 do
                  synth :saw, attack: 4+c, decay: 8+c, release: 4+c, amp: 0.5
                end
              end
            end
          end
        end
      end
      sleep 4
    end
    if c < 3
      sleep n ** 2
      bateria_off = (c+=1).odd?
    else
      bateria_off = true
      cue :continue
      stop
    end
  end
end

in_thread do
  sync :continue
  sleep 7
  virada
  sleep 0.25
  virada
  sleep 0.25
  virada
end