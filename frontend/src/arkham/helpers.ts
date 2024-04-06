import ita from '@/digests/ita.json'
import chn from '@/digests/chn.json'

export function toCapitalizedWords(name: string) {
  const words = name.match(/[A-Za-z][a-z']*/g) || [];
  return capitalize(words.map(lowercase).join(" "));
}

function capitalize(word: string) {
  return word.charAt(0).toUpperCase() + word.substring(1);
}

function lowercase(word: string) {
  return word.charAt(0).toLowerCase() + word.substring(1);
}

const baseUrl = import.meta.env.PROD ? "https://raw.gitmirror.com/klingeling/ArkhamHorror/main/frontend/public" : ''

export function imgsrc(src: string) {
  const language = localStorage.getItem('language') || 'en'
  const path = src.replace(/^\//, '')
  switch (language) {
    case 'it': {
      const exists = ita.includes(path)
      return exists ? `${baseUrl}/img/arkham/ita/${src.replace(/^\//, '')}` : `${baseUrl}/img/arkham/${src.replace(/^\//, '')}`
    }
    case 'zh': {
      const exists = chn.includes(path)
      return exists ? `${baseUrl}/img/arkham/chn/${src.replace(/^\//, '')}` : `${baseUrl}/img/arkham/${src.replace(/^\//, '')}`
    }
    default: return `${baseUrl}/img/arkham/${src.replace(/^\//, '')}`
  }
}

export function pluralize(w: string, n: number) {
  const language = localStorage.getItem('language') || 'en'
  switch (language) {
    case 'it': {
      return `${n} ${w}${n == 1 ? '' : 's'}`
    }
    case 'zh': {
      return `${n}${w}${n == 1 ? '' : ''}`
    }
    default: return `${n} ${w}${n == 1 ? '' : 's'}`
  }
}

export function replaceIcons(body: string) {
  return body.
    replace(/{action}/g, '<span class="action-icon"></span>').
    replace(/{fast}/g, '<span class="fast-icon"></span>').
    replace(/{willpower}/g, '<span class="willpower-icon"></span>').
    replace(/{intellect}/g, '<span class="intellect-icon"></span>').
    replace(/{combat}/g, '<span class="combat-icon"></span>').
    replace(/{agility}/g, '<span class="agility-icon"></span>').
    replace(/{wild}/g, '<span class="wild-icon"></span>').
    replace(/{guardian}/g, '<span class="guardian-icon"></span>').
    replace(/{seeker}/g, '<span class="seeker-icon"></span>').
    replace(/{rogue}/g, '<span class="rogue-icon"></span>').
    replace(/{mystic}/g, '<span class="mystic-icon"></span>').
    replace(/{survivor}/g, '<span class="survivor-icon"></span>').
    replace(/{elderSign}/g, '<span class="elder-sign"></span>').
    replace(/{curse}/g, '<span class="curse-icon"></span>').
    replace(/{bless}/g, '<span class="bless-icon"></span>')
}
