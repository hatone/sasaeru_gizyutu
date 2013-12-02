class GeneratorsController < ApplicationController
    ABSOLUTE_PATH = '/Users/hatone/SandBox/sasaeru/pub_images/'
    RELATIVE_PATH = 'public/images/'
    WIDTH, HEIGHT = 480, 640

  def render_list
    latest_id = Image.last.id.to_i
    @list1 = Image.find(latest_id)
    @list2 = Image.find(latest_id-1)
    @list3 = Image.find(latest_id-2)
    @list4 = Image.find(latest_id-3)
    @list5 = Image.find(latest_id-4)
    @list6 = Image.find(latest_id-5)
  end

  def index
    render_list
    @image_form = ImageForm.new
  end

  def create
    seed = Random.new_seed.to_s + request.env["HTTP_USER_AGENT"]
    id = Digest::SHA1.hexdigest(seed)
    filename = id + '.png'
    @image_form = ImageForm.new(params[:image_form])
  
    surface = Cairo::ImageSurface.new(WIDTH, HEIGHT)
    context = Cairo::Context.new(surface)

    color = @image_form.color

    context.set_source_color(Cairo::Color::WHITE)
    context.rectangle(0, 0, WIDTH, HEIGHT)
    context.fill

    context.set_source_color(Cairo::Color::WHITE)
    context.font_size = 25

    context.set_source_color(Cairo::Color::BLACK)
    x, y, rw, rh = 0, 0, 480, 32
    context.rectangle(x, y, rw, rh)
    context.fill_preserve

    context.set_source_color(Cairo::Color::BLACK)
    x, y, rw, rh = 0, 384, 480, 256
    context.rectangle(x, y, rw, rh)
    context.fill_preserve

    context_footer = Cairo::Context.new(surface)
    context_footer.set_source_rgb(hex2rgb(color))
    x, y, rw, rh = 0, 580, 480, 176
    context_footer.rectangle(x, y, rw, rh)
    context_footer.fill_preserve

    title = generate_pango_layout(@image_form.title, "Hiragino Mincho Pro W6 Bold 120", context)
    context.move_to(0, 50)
    context.show_pango_layout(title)

  
    #サブタイトル
    context_subtitle = Cairo::Context.new(surface)
    context_subtitle_layout = generate_pango_layout(@image_form.subtitle, "Droid Sans Bold 25", context_subtitle)
    markup = "<span background='" + color + "'>" + @image_form.subtitle + "</span>"
    attr_list, text = Pango.parse_markup(markup)
    context_subtitle_layout.attributes = attr_list
    context_subtitle.move_to(0, 250)
    context_subtitle.show_pango_layout(context_subtitle_layout)

    #著者名
    author_name = generate_pango_layout(@image_form.author_name, "20", context)
    context.move_to(0, 300)
    context.show_pango_layout(author_name)

    #帯のキャッチコピー
    context_subtitle_under = Cairo::Context.new(surface)
    subtitle_under_layout = generate_pango_layout(@image_form.subtitle2, "Droid Sans Bold 56", context_subtitle_under)
    context_subtitle_under.move_to(0, 400)
    context_subtitle_under.set_source_rgb(hex2rgb(color))
    context_subtitle_under.show_pango_layout(subtitle_under_layout)

    set_fixed_texts(context)

    surface.write_to_png(RELATIVE_PATH + filename)

    price = (rand(99) +1)*100

    image = Image.new(filename: filename, price: price)
    image.save

    redirect_to :action => "show", :id =>id
  end

  def show
    render_list
    @id = params[:id]
    @ua = request.env["HTTP_USER_AGENT"]
    @test1 = "test"

    filename = @id +'.png'
    @image_exist = File.exist?(ABSOLUTE_PATH + filename)
  end

  private
  def generate_pango_layout(text, text_config, context)
    font = Pango::FontDescription.new(text_config)
    pango_object = context.create_pango_layout
    pango_object.font_description = font
    pango_object.width = WIDTH * Pango::SCALE
    pango_object.alignment = Pango::ALIGN_CENTER
    pango_object.text = text
    return pango_object
  end

  private
  def set_fixed_texts(context)
    sasaeru = generate_pango_layout("を支える技術", "Hiragino Mincho Pro W6 56", context)
    context.move_to(0, 170)
    context.show_pango_layout(sasaeru)

    chyo = generate_pango_layout("[著]", "Droid Sans", context)
    context.move_to(0, 320)
    context.show_pango_layout(chyo)
  end

  private
  def hex2rgb(hex_color) 
    base_color = hex_color.delete("#")
    split_color = base_color.unpack("a2" * (base_color.size / 2))
    p split_color[0].hex, split_color[1].hex, split_color[2].hex
    return (split_color[0].hex)/255.0, (split_color[1].hex)/255.0, (split_color[2].hex)/255.0
  end  
end
