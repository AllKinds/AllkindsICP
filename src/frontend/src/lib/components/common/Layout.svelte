<script lang="ts">
	import { styleStore } from "$lib/stores/tasks/colorSelect";
	import Footer from "./Footer.svelte";
	import Logo from "./Logo.svelte";
</script>

<div class="mx-auto min-h-screen flex flex-col scroll-smooth ">
	<!-- header/nav -->
	<div  class="bg-transparent h-12 fixed w-[100%] 
	">
		<div class="mx-auto bg-transparent flex justify-between h-12 w-11/12 ">
			<span class="self-center"><Logo /></span>
			<slot name="title" />
			<!--unused -->

			<slot name="nav" />
		</div>
	</div>

	<!-- main content -->
	<div class="mx-auto pt-7 pb-24 w-11/12">
		<slot name="main" />
	</div>

	<Footer/>
</div>
