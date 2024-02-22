<script lang="ts" setup>
import { ref } from 'vue';
import { imgsrc } from '@/arkham/helpers'

const card = ref<string | null>(null);
const reversed = ref<boolean>(false);
const cardOverlay = ref<HTMLElement | null>(null);

const getReversed = (el: HTMLElement) => {
  return el.classList.contains('Reversed')
}

const getRotated = (el: HTMLElement) => {
  var st = window.getComputedStyle(el, null);
  var tr = st.getPropertyValue("-webkit-transform") ||
           st.getPropertyValue("-moz-transform") ||
           st.getPropertyValue("-ms-transform") ||
           st.getPropertyValue("-o-transform") ||
           st.getPropertyValue("transform") ||
           "none"

  if (tr !== "none") {
    const [a, b] = tr.split('(')[1].split(')')[0].split(',');

    var angle = Math.round(Math.atan2(parseFloat(b), parseFloat(a)) * (180/Math.PI));

    return angle == 90
  }

  return false
}

const getPosition = (el: HTMLElement) => {
  const rect = el.getBoundingClientRect()

  // we do not know the height of the overlay, BUT we can calculate it from the width and height of the target.
  // since we know the overlay's width is 300px we get the ratio and multiply the height
  // afterwards we add this new height to it's top to figure out if we are off the screen. If we are we use the
  // bottom value instead


  const ratio = rect.width > rect.height ? rect.height / rect.width : rect.width / rect.height

  const rotated = getRotated(el)

  const height = 420
  const top = rect.top + window.scrollY - 40;

  const bottom = top + height

  const width = 420
  const left = rect.right + window.scrollX + 10;

  const right = left + width

  const newTop = Math.max(0, bottom > window.innerHeight ?
    (rotated ? rect.bottom - height + rect.height : rect.bottom - height) + window.scrollY - 40 :
    top)

    const newLeft = Math.max(0, right > window.innerWidth ?
    (rotated ? rect.left - width : rect.left - width) + window.scrollX - 10 :
    left)

  return { top: newTop, left: newLeft }
}

const getImage = (el: HTMLElement): string | null => {
  if (el instanceof HTMLImageElement) {
    if (el.classList.contains('card')) {
      if (el.closest(".revelation")) {
        return null
      }
      return el.src
    }
  } else if (el instanceof HTMLDivElement) {
    if (el.classList.contains('card')) {
      return el.style.backgroundImage.slice(4, -1).replace(/"/g, "")
    }
  } else if (el instanceof HTMLElement) {
    if(el.dataset.imageId) {
      return imgsrc(`cards/${el.dataset.imageId}.jpg`)
    }
    if(el.dataset.target) {
      const target = document.querySelector(`[data-id="${el.dataset.target}"]`) as HTMLElement
      if (target !== null) {
        return getImage(target)
      }
    }
    if(el.dataset.image) {
      return el.dataset.image
    }
  }

  return null
}

document.addEventListener('mouseover', (event) => {
  if (cardOverlay.value === null) {
    return
  }

  card.value = getImage(event.target as HTMLElement)
  reversed.value = getReversed(event.target as HTMLElement)

  if (event.target instanceof HTMLImageElement) {
    if (event.target.classList.contains('card')) {
      const { top, left } = getPosition(event.target)

      cardOverlay.value.style.top = `${top}px`
      cardOverlay.value.style.left = `${left}px`

      return
    }
  } else if (event.target instanceof HTMLDivElement) {
    if (event.target.classList.contains('card')) {
      const { top, left } = getPosition(event.target)

      cardOverlay.value.style.top = `${top}px`
      cardOverlay.value.style.left = `${left}px`
      return
    }
  } else if (event.target instanceof HTMLElement) {
    if(event.target.dataset.imageId) {
      const { top, left } = getPosition(event.target)

      cardOverlay.value.style.top = `${top}px`
      cardOverlay.value.style.left = `${left}px`
      return
    }
    if(event.target.dataset.target) {
      const target = document.querySelector(`[data-id="${event.target.dataset.target}"]`) as HTMLElement
      if (target === null) {
        return
      }
      const { top, left } = getPosition(target)

      cardOverlay.value.style.top = `${top}px`
      cardOverlay.value.style.left = `${left}px`
      return
    }
    if(event.target.dataset.image) {
      const { top, left } = getPosition(event.target)

      cardOverlay.value.style.top = `${top}px`
      cardOverlay.value.style.left = `${left}px`
      return
    }
  }
})
</script>

<template>
  <div class="card-overlay" ref="cardOverlay">
    <img v-if="card" :src="card" :class="{ reversed }" />
  </div>
  <!-- Magic for border radius -->
  <svg style="visibility: hidden" width="0" height="0">
    <defs>
      <filter id="filter-radius">
        <!-- Create a blur of 4px radius from the original image -->
        <!-- (Transparent pixels are ignored, thus the blur radius starts at the corner of the image) -->
        <feGaussianBlur in="SourceGraphic" stdDeviation="6" result="blur" />
        <!-- Filter out the pixels where alpha values that are too low, in this case the blurred corners are filtered out -->
        <feColorMatrix in="blur" mode="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 100 -50" result="mask" />
        <!-- As the final result is now blurred, we need to use the mask we obtained from previous step to cut from the original source -->
        <feComposite in="SourceGraphic" in2="mask" operator="atop" />
      </filter>
    </defs>
  </svg>
</template>

<style lang="scss">
.card-overlay {
  position: absolute;
  z-index: 1000;
  max-width: 420px;
  max-height: 420px;
  height: fit-content;
  display: flex;
  filter: url('#filter-radius');
  img {
    object-fit: contain;
    width: auto;
    height: auto;
    max-width: 100%;
    max-height: 100%;
    filter: url('#filter-radius');
  }
}


.reversed {
  transform: rotateZ(180deg);
}
</style>
