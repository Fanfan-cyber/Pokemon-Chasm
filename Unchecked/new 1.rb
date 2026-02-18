class Battle::Battler
  alias old_pbUseMove pbUseMove
  def pbUseMove(choice, specialUsage = false)

    # 检查对手是否有该特性
    if @battle.allOtherSideBattlers(@index).any? { |b| b.hasActiveAbility?(:TURN) }

      move = choice[2]
      turn = @battle.turnCount
      even_turn = turn.even?

      # 判断当前选择的技能是否不符合规则
      if even_turn && move.damagingMove? || !even_turn && move.statusMove?

        # 寻找符合规则的技能
        valid_moves = @moves.select { |m| even_turn ? m.statusMove? : m.damagingMove? }

        if valid_moves.empty?

          # 无符合规则的技能，强制使用挣扎
          new_move = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(:STRUGGLE))
          @battle.pbDisplay(_INTL("{1}没有合适的技能，只能使用{2}！", pbThis, new_move.name))
        else

          # 自动选择第一个符合规则的技能
          new_move = valid_moves.first
          @battle.pbDisplay(_INTL("{1}不能使用{2}，自动改为{3}！", pbThis, move.name, new_move.name))
        end

        choice[2] = new_move
      end
    end

    old_pbUseMove(choice, specialUsage)
  end
end