
function skillsort_comparenumber(num1, num2)
    if num1 == num2 then
        return 0
    elseif num1 < num2 then
        return -1
    else
        return 1
    end
end

function skillsort_name(p1, p2)
    return c_textcompare(p1.config_skill.name, p2.config_skill.name)
end

function skillsort_name_inv(p1, p2)
    return c_textcompare(p2.config_skill.name, p1.config_skill.name)
end

function skillsort_level(p1, p2)
    return skillsort_comparenumber(p1.playerlevel, p2.playerlevel)
end

function skillsort_level_inv(p1, p2)
    return skillsort_comparenumber(p2.playerlevel, p1.playerlevel)
end

function skillsort_learn(p1, p2)
    return skillsort_comparenumber(p1.learntype, p2.learntype)
end

function skillsort_learn_inv(p1, p2)
    return skillsort_comparenumber(p2.learntype, p1.learntype)
end

function skillsort_spell(p1, p2)
    return skillsort_comparenumber(p1.config_skill.spellway, p2.config_skill.spellway)
end

function skillsort_spell_inv(p1, p2)
    return skillsort_comparenumber(p2.config_skill.spellway, p1.config_skill.spellway)
end
