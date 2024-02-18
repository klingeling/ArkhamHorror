import ita from '@/digests/ita.json'

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
      console.log(ita, path)
      const exists = ita.includes(path)
      return exists ? `${baseUrl}/img/arkham/ita/${src.replace(/^\//, '')}` : `${baseUrl}/img/arkham/${src.replace(/^\//, '')}`
      break;
    }
    case 'zh': {
      console.log(chn, path)
      const exists = chn.includes(path)
      return exists ? `${baseUrl}/img/arkham/chn/${src.replace(/^\//, '')}` : `${baseUrl}/img/arkham/${src.replace(/^\//, '')}`
      break;
    }
    default: return `${baseUrl}/img/arkham/${src.replace(/^\//, '')}`
  }
}

export function pluralize(w: string, n: number) {
  return `${n} ${w}${n == 1 ? '' : ''}`
}
