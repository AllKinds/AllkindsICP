<script lang="ts">
	import AllkindsLogo from '../common/AllkindsLogo.svelte';
	import PageTransition from './PageTransition.svelte';
</script>

<PageTransition>
	<content class="mx-auto min-h-screen flex flex-col w-auto ">
		<!-- header/nav -->
		<div class=" mx-auto self-center flex justify-between px-3 md:px-8 lg:px-12 h-12 fixed w-[100%] bg-transparant" >
			<AllkindsLogo />

			<slot name="title" />

			<slot name="nav" />
		</div>

		<!-- main content -->
		<main class="mx-auto px-3 md:px-8 lg:px-12 pt-8 ">
			<slot name="main" />
		</main>
	</content>
</PageTransition>
