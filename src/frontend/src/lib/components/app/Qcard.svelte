<script lang="ts">
	import type { Question } from "src/declarations/backend/backend.did";



  export let question: any;
</script>


<div class="odd:dark:bg-slate-700 even:dark:bg-slate-700/50 odd:bg-slate-100 even:bg-slate-100/50 w-full rounded-md mx-auto flex flex-col justify-center items-center p-2 md:p-3 lg:p-5">
  <h2 class=" w-fit">{question.question}</h2>
  <span>Created: {question.created}</span>
  <span>Hash: {question.hash}</span>
  <span>Color: {question.color}</span>
  <span>Creator: {question.creater}</span>
  <div class="w-full flex flex-row justify-center items-center dark:text-slate-700 pt-3">
      <button class="bg-green-400 hover:bg-green-500 h-20 w-4/12 cursor-pointer rounded-l-lg flex justify-center items-center">
        <h3>YES</h3>
      </button>
      <div class="bg-red-400 hover:bg-red-500 h-20 w-4/12 cursor-pointer rounded-r-lg flex justify-center items-center">
        <h3>NO</h3>
      </div>
  </div>
</div>



      <!-- <div class="
        bg-gradient-to-br from-DF-blue via-DF-red to-DF-yellow
        
        font-semibold 
        p-0.5 
        my-10
        md:mx-0
        rounded-xl
        cursor-pointer
      ">
        <button class="trans-300 p-2 px-8 text-DF-navy bg-slate-800/80 w-24 h-24 rounded-xl hover:bg-green-200/90" on:click>
          YES
        </button>
      </div>
      <div class="
        bg-gradient-to-br from-DF-blue via-DF-red to-DF-yellow
        
        font-semibold 
        p-0.5 
        my-10
        md:mx-0
        rounded-xl
        cursor-pointer
      ">
        <button class="trans-300 p-2 px-8 text-DF-navy bg-slate-800/80 w-24 h-24 rounded-xl hover:bg-red-200/90" on:click>
          NO
        </button>
      </div> -->