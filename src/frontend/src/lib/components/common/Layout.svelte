<script lang="ts">
	import Logo from './Logo.svelte';
</script>

<div class="mx-auto min-h-screen flex flex-col scroll-smooth px-2 md:px-10">
	<!-- header/nav -->

	<div class="mx-auto bg-transparent flex justify-between h-12 w-full">
		<span class="self-center"><Logo /></span>

		<slot name="nav" />
	</div>

	<!-- main content -->
	<div class="mx-auto pb-24 w-full">
		<slot name="main" />
	</div>
</div>
