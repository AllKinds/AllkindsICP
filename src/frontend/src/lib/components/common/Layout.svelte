<script lang="ts">
	import PageTransition from './PageTransition.svelte';
	export let headerBg: string
</script>



<PageTransition>
	<div class="mx-auto min-h-screen flex flex-col ">
		<!-- header/nav -->
		<div class="{headerBg} h-12 fixed w-[100%] " >
			<div class="mx-auto self-center bg-transparent flex justify-between h-12 w-11/12 xl:w-10/12 ">
				<div class="
					self-center
					font-semibold 
					text-lg 
					bg-clip-text 
					text-transparent 
					bg-gradient-to-r from-DF-blue via-DF-red to-DF-yellow
				">
					Allkinds
				</div>
			
				<slot name="title" /> <!--unused -->
			
				<slot name="nav" />
			</div>
		</div>

		<!-- main content -->
		<div class="mx-auto pt-8 w-11/12 xl:w-10/12">
			<slot name="main" />
		</div>
	</div>
</PageTransition>
