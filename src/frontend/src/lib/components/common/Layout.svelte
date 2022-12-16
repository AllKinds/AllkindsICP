<script lang="ts">
	import AllkindsLogo from '../common/AllkindsLogo.svelte';
	import PageTransition from './PageTransition.svelte';
</script>

<PageTransition>
	<content class="mx-auto min-h-screen flex w-11/12 flex-col">
		<!-- header/nav -->
		<header
			class="mx-auto flex self-center justify-between pt-2 h-12 w-11/12 fixed bg-transparant"
		>
			<AllkindsLogo />

			<slot name="title" />

			<slot name="nav" />
		</header>

		<!-- main content -->
		<main class="mx-auto w-full pt-8">
			<slot name="main" />
		</main>
	</content>
</PageTransition>
