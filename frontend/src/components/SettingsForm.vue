<script lang="ts" setup>
import { ref } from 'vue';
import type { User } from '@/types';

export interface Props {
  user: User
  updateBeta: (setting: boolean) => void
}

const props = defineProps<Props>()
const beta = ref(props.user.beta ? "On" : "Off")

const betaUpdate = async () => props.updateBeta(beta.value == "On")

const currentLanguage = localStorage.getItem('language') ?? 'en'

const language = ref(currentLanguage)

const updateLanguage = () => {
  localStorage.setItem('language', language.value)
}
</script>

<template>
  <div class="settings">
    <h1>{{$t('settings')}}</h1>

    <fieldset>
      <legend>{{$t('language')}}</legend>
      <p>{{$t('thisWillChangeTheLanguage')}}</p>
      <select v-model="$i18n.locale" @change="updateLanguage">
        <option value="en">English</option>
        <option value="it">Italiano</option>
        <option value="zh">中文</option>
      </select>
    </fieldset>

    <fieldset>
      <legend>{{$t('enrollInBeta')}}</legend>
      <p>{{$t('betaFeatures')}}</p>
      <label>{{$t('on')}} <input type="radio" name="beta" value="On" v-model="beta" @change="betaUpdate" /></label>
      <label>{{$t('off')}} <input type="radio" name="beta" value="Off" v-model="beta" @change="betaUpdate" /></label>
    </fieldset>
  </div>
</template>

<style lang="scss" scoped>
.settings {
  width: 75vw;
  margin: 0 auto;
  margin-top: 20px;
  background: rgba(255, 255, 255, 0.7);
  padding: 10px;
  border-radius: 10px;
}

input[type="radio"] {
  display: unset;
}

h1 {
  margin: 0;
  padding: 0;
}
</style>
