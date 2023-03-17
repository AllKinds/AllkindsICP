<script lang="ts">
	//export let headerBg: string;
</script>

<div class="mx-auto min-h-screen flex flex-col scroll-smooth ">
	<!-- header/nav -->
	<div class=" h-12 fixed w-[100%] border-b dark:border-none	">
		<div class="mx-auto self-center bg-transparent flex justify-between h-12 w-11/12">
			<div
				class="
				self-center
				font-semibold 
				text-lg 
				bg-clip-text 
				text-transparent 
				bg-gradient-to-r from-DF-blue via-DF-red to-DF-yellow
			"
			>
				Allkinds
			</div>

			<slot name="title" />
			<!--unused -->

			<slot name="nav" />
		</div>
	</div>

	<!-- main content -->
	<div class="mx-auto pt-7 pb-24 w-11/12">
		<slot name="main" />
	</div>
</div>
